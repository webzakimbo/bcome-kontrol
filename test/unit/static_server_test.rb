load "#{File.dirname(__FILE__)}/../base.rb"

class StaticServerTest < ActiveSupport::TestCase
  include UnitTestHelper

  def test_should_be_able_to_create_a_static_server
    # Given
    identifier = "app1"
    public_ip_address = "217.199.177.83" 

    config = { views: {
      description: "Test server",
      identifier: identifier,
      public_ip_address: public_ip_address
      }
    }

    # When
    static_server = ::Bcome::Node::Server::Static.new(config)

    # Then
    assert static_server.is_a?(::Bcome::Node::Server::Static)
    assert static_server.identifier == identifier
    assert static_server.public_ip_address == public_ip_address
  end

  def test_should_set_internal_ip_address_if_provided
    # Given
    identifier = "app1"
    public_ip_address = "217.199.177.83"
    internal_ip_address = "10.0.0.4"

    config = { views: {
      description: "Test server",
      identifier: identifier,
      public_ip_address: public_ip_address,
      internal_ip_address: internal_ip_address
      }
    }

    # When
    static_server = ::Bcome::Node::Server::Static.new(config)

    # Then
    assert static_server.internal_ip_address == internal_ip_address
  end

  def test_should_be_able_to_set_description_on_server
    # Given
    description = given_a_random_string_of_length(10)
    identifier = "foo"
    public_ip_address = "217.199.177.83"

    config = {
      views: {
        description: "Test server",
        identifier: identifier,
        public_ip_address: public_ip_address,
        description: description
      }
    }

    # When 
    server = ::Bcome::Node::Server::Static.new(config)

    # Then
    assert server.description == description
    assert server.has_description?
  end

end
