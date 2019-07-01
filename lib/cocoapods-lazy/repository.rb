require 'dotenv'
require 'shellwords'

class Repository
  def initialize(file)
    Dotenv.load(file)
    @user = Shellwords.escape ENV['STORE_USER']
    @password = Shellwords.escape ENV['STORE_PASSWORD']
    @base_url = ENV['BASE_URL']
  end

  def download(name:)
    zip_name = "#{name}.zip"
    url = @base_url + zip_name
    puts `curl --fail -v -u #{@user}:#{@password} #{url} --output #{zip_name}`
    `unzip #{zip_name}`
    `rm -rf #{zip_name}`
  end

  def upload(name:)
    zip_name = "#{name}.zip"
    unless File.exist?(zip_name)
      puts "Make zip: #{zip_name}"
      `zip -9 -r -y #{zip_name} Pods`
    end
    url = @base_url + zip_name
    puts "Storing to #{url}"
    `curl --fail -v -u #{@user}:#{@password} --upload-file #{zip_name} #{url}`
  end
end
