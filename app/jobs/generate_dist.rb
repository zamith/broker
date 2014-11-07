require_relative 'adapters/sidekiq'

module Jobs
  class GenerateDist < Adapters::Sidekiq
    def perform(force = false, branch_name = "develop")
     @branch_name = branch_name
      within_repo_dir do
        if changes_from_previous_dist.size > 0 || force
          repo.merge("origin/#{branch_name}")
          do_not_process_images
          create_dist
        end
      end
    end

    private
    attr_reader :repo, :branch_name

    def within_repo_dir
      Dir.chdir ENV['REPO_PATH'] do
        @repo = Git.open('.')
        yield
      end
    end

    def changes_from_previous_dist
      @_changes ||= begin
        repo.branch(branch_name).checkout
        repo.fetch
        repo.log.between("HEAD", "origin/#{branch_name}")
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
      dist_name = "dist-#{branch_name}-#{current_time}"
      FileUtils.mv 'dist.zip', dist_path(dist_name)
      Dist.create branch_name: branch_name, url: "#{dist_name}", release_manifest: parse_commits(changes_from_previous_dist)
    end

    def current_time
      DateTime.now.in_time_zone("Central Time (US & Canada)").strftime('%Y-%m-%d-%H-%M')
    end

    def parse_commits(commits)
      commits.map do |commit|
        "#{commit.message.split("\n").first} (#{commit.author.try(:name)})"
      end.join("\n")
    end

    def dist_path(dist_name)
      Dist.new(url: dist_name).path
    end
  end
end
