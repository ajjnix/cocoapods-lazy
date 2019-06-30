class PodfileLock
  def initialize(filename)
    @filename = filename
  end

  def checksum
    begin
      File.open(@filename).read().match(/(?<=PODFILE CHECKSUM: )\w*/).to_s
    rescue
      nil
    end
  end
end
