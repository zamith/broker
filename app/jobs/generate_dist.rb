class GenerateDist < Adapters::Sidekiq
  URI = "git@gitlab.com:seven/bid.git"
  NAME = "bid"

  def perform
    temp_dir do
      Git.clone(URI, NAME)
      Dir.chdir "bid" do
        File.open('grunt/concurrent.js', 'w') do |file|
            file.write grunt_template
        end
        system("grunt deploy")
      end
    end
  end

  private

  def temp_dir
    Dir.mktmpdir do |temp_dir|
      Dir.chdir temp_dir do
        yield temp_dir
      end
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
end
