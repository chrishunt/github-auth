module Github::Auth
  # Represents a username/key pair from GitHub
  Key = Struct.new(:username, :key) do
    def to_a
      [self]
    end

    def to_s
      "#{key} #{url}"
    end

    def url
      "https://github.com/#{username}"
    end
  end
end
