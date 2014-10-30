require_relative 'adapters/sidekiq'

module Jobs
  class GenerateDist < Adapters::Sidekiq
    def perform
      within_repo_dir do
        repo = Git.open('.')
        repo.branch('develop').checkout
        repo.fetch
        changes = repo.log.between("HEAD", "origin/develop").map(&:message)
        repo.merge('origin/develop')
        do_not_process_images
        create_dist
        repo.reset_hard('HEAD')
        save_dist(changes)
        remove_older_dist
      end
    end

    private
    def within_repo_dir
      Dir.chdir ENV['REPO_PATH'] do
        yield
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
      system('grunt deploy && zip -9 -r dist.zip dist')
    end

    def save_dist(changes)
      sleep 2
      dist_name = "dist-#{DateTime.now.strftime('%Y-%m-%d-%H-%M')}"
      FileUtils.mv 'dist.zip', dist_path(dist_name)
      Dist.create branch_name: 'develop', url: "#{dist_name}", release_manifest: changes.join("\n")
    end

    def remove_older_dist
      if Dist.count > Dist::DIST_LIMIT
        Dist.first.destroy
      end
    end

    def dist_path(dist_name)
      Dist.new(url: dist_name).dist_path
    end
  end
end
