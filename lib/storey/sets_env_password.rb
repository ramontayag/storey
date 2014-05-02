module Storey
  class SetsEnvPassword

    def self.with(password)
       ENV['PGPASSWORD'] = password.to_s
    end

  end
end
