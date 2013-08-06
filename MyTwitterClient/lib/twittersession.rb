class TwitterSession
  include Singleton

  CONSUMER_KEY = 'auJ8l7unaSfzIRN1QpHNA'
  CONSUMER_SECRET = 'xHWQQT0DQvaisOsVJIODH2G4Xi6wOUpsuQ3FTWrm6lI'
  CONSUMER = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET,
  :site => "https://twitter.com")

  def initialize
    self.access_token
  end

  def get_token
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    Launchy.open(authorize_url)

    print "What is your twitter pin: "
    input = gets.chomp

    access_token = request_token.get_access_token(
    :oauth_verifier => input
    )
    access_token
  end

  def set_user
    User.find_by_username(self.access_token.params[:screen_name]) ||
    User.create!(:username => self.access_token.params[:screen_name],
                :twitter_user_id => self.access_token.params[:user_id])
  end

  def access_token(token_file = "my_token.yml")
    if File.exist?(token_file)
      File.open(token_file) { |f| YAML.load(f) }
    else
      access_token = self.get_token
      File.open(token_file, "w") { |f| YAML.dump(access_token, f) }

      @access_token = access_token
    end

    @access_token ||= get_token
  end

  def current_user
    @current_user ||= set_user
  end

  def get(uri)
    access_token.get(uri).body
  end

  def post(uri)
    access_token.post(uri).body
  end
end
