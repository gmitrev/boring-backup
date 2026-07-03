module NoopBackup
  class Tee
    def initialize(writers) = @writers = writers

    def write(chunk)
      @writers.each { |writer| writer.write(chunk) }
      chunk.bytesize
    end
  end
end
