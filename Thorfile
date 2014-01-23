# encoding: utf-8
# Thorfile heavily based on RiotGames(https://github.com/RiotGames/rbenv-cookbook/blob/master/Thorfile). Thanks Guys!

require 'bundler'
require 'bundler/setup'
require 'berkshelf/thor'
require 'strainer/thor'

class Default < Thor

  desc "tag", "Create a tag from metadata version"
  def tag
    unless clean?
      say "There are files that need to be committed first.", :red
      exit 1
    end

    tag_version

  end


  private

    def current_version
      Berkshelf::CachedCookbook.from_path(source_root).version
    end

    def clean?
      sh_with_excode("git diff --exit-code")[1] == 0
    end

    def tag_version
      sh "git tag -a -m \"Version #{current_version}\" #{current_version}"
      say "Tagged: #{current_version}", :green
      yield if block_given?
      sh "git push --tags"
    rescue => e
      say "Untagging: #{current_version} due to error", :red
      sh_with_excode "git tag -d #{current_version}"
      say e , :red
      say "Increase your version in metadata.rb", :red
      exit 1
    end

    def source_root
      Pathname.new File.dirname(File.expand_path(__FILE__))
    end

    def sh(cmd, dir = source_root, &block)
      out, code = sh_with_excode(cmd, dir, &block)
      code == 0 ? out : raise(out.empty? ? "Running `#{cmd}` failed. Run this command directly for more detailed output." : out)
    end

    def sh_with_excode(cmd, dir = source_root, &block)
      cmd << " 2>&1"
      outbuf = ''

      Dir.chdir(dir) {
        outbuf = `#{cmd}`
        if $? == 0
          block.call(outbuf) if block
        end
      }

      [ outbuf, $? ]
    end

end
