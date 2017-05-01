
def given_a_random_string_of_length(string_length = 50)
  o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten 
  return (0...string_length).map { o[rand(o.length)] }.join
end

def given_estate_setup_params
  description = given_a_random_string_of_length(5)
  identifier = given_a_random_string_of_length(5)
  type = given_a_random_string_of_length(5)

  params = {
    :view_data => {
      :description => description,
      :identifier => identifier,
      :type => type
    }
  }
  return params
end

def given_a_dummy_estate
  return ::Bcome::Node::Estate.new(given_estate_setup_params)
end
