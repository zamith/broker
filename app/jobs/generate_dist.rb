require_relative 'adapters/sidekiq'

module Jobs
  class GenerateDist < Adapters::Sidekiq
    def perform
      within_repo_dir do
        repo = Git.open('.')
        repo.branch('develop').checkout
        repo.pull('origin', 'develop')
        do_not_process_images
        create_dist
        repo.reset_hard('HEAD')
        save_dist
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

    def save_dist
      sleep 2
      dist_name = "dist-#{DateTime.now.strftime('%Y-%m-%d-%H-%M')}"
      FileUtils.mv 'dist.zip', "#{Rails.root}/public/dists/#{dist_name}.zip"
      Dist.create branch_name: 'develop', url: "#{dist_name}"
    end
  end
end
