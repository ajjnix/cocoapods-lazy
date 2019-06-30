require 'dotenv'

class Repository
  def initialize(file)
    Dotenv.load("#{file}")
    @user = ENV['STORE_USER']
    @password = ENV['STORE_PASSWORD']
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
    url = @base_url + zip_name
    puts "Make zip: #{zip_name}"
    `zip -9 -r -y #{zip_name} Pods`
    puts "Storing to #{url}"
    `curl --fail -v -u #{@user}:#{@password} --upload-file #{zip_name} #{url}`
  end
end
