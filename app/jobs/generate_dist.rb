require_relative 'adapters/sidekiq'

module Jobs
  class GenerateDist < Adapters::Sidekiq
    attr_reader :repo

    def perform(force = false)
      within_repo_dir do
        if changes_from_previous_dist.size > 0 || force
          repo.merge('origin/develop')
          do_not_process_images
          create_dist
        end
      end
    end

    private
    def within_repo_dir
      Dir.chdir ENV['REPO_PATH'] do
        @repo = Git.open('.')
        yield
      end
    end

    def changes_from_previous_dist
      @_changes ||= begin
        repo.branch('develop').checkout
        repo.fetch
        repo.log.between("HEAD", "origin/develop")
      end
    end

    def do_not_process_images
      File.open('grunt/concurrent.js', 'w') do |file|
        file.write grunt_template
      end
    end

    def grunt_template
      <<-GRUNT.gsub(/^ {4}/, '')
      module.exports = {
          server: [
              'sass',
              'copy:server',
              'bower:install'
          ],
          dist: [
              'sass',
              // 'imagemin',
              'htmlmin'
          ]
      };
      GRUNT
    end

    def create_dist
      successfull = system('grunt deploy && zip -9 -r dist.zip dist')
      if successfull
        repo.reset_hard('HEAD')
        save_dist
      else
        Mailer.error_creating_dist.deliver
      end
    end

    def save_dist
      sleep 2
      dist_name = "dist-#{DateTime.now.strftime('%Y-%m-%d-%H-%M')}"
      FileUtils.mv 'dist.zip', dist_path(dist_name)
      Dist.create branch_name: 'develop', url: "#{dist_name}", release_manifest: parse_commits(changes_from_previous_dist)
    end

    def parse_commits(commits)
      commits.map do |commit|
        "#{commit.message} (#{commit.author.try(:name)})"
      end.join("\n")
    end

    def dist_path(dist_name)
      Dist.new(url: dist_name).dist_path
    end
  end
end
