load "#{File.dirname(__FILE__)}/../base.rb"

class StaticServerTest < ActiveSupport::TestCase
  include UnitTestHelper

  def test_should_be_able_to_create_a_static_server
    # Given
    identifier = "app1"
    public_ip_address = "X.X.X.X"

    config = { view_data: {
      identifier: identifier,
      public_ip_address: "X.X.X.X"
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
    public_ip_address = "X.X.X.X"
    internal_ip_address = "Y.Y.Y.Y"

    config = { view_data: {
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

  def test_should_ensure_that_required_fields_are_required
    # Given/When/Then
    assert_raise ::Bcome::Exception::MissingIdentifierOnView do
      c = ::Bcome::Node::Server::Static.new({ view_data: { public_ip_address: "XX.XX.XX.XX.XX" } })
      puts c.inspect
    end

    # Given/When/Then
    # We require either an internal or a public ip address
    assert_raise ::Bcome::Exception::MissingIpaddressOnServer do
      ::Bcome::Node::Server::Static.new({ view_data: { identifier: "foo" }})
    end 
  end

  def test_should_ensure_that_only_valid_ipv4_address_are_allowed
    # Given
    invalid_addresses = [  
      nil,
      "obviously not an ipv4 address",
      "a.255.255.255",
      "255.a.255.255",
      "255.255.a.255",
      "255.255.255.a",
      "256.255.255.a"
    ]

    # TODO: raise a bcome exception 

    # When/then - public address
    invalid_addresses.each do |invalid_address|
      assert_raise IPAddr::InvalidAddressError do
        ::Bcome::Node::Server::Static.new( { view_data: { identifier: "foo", public_ip_address: invalid_address }})
      end
    end

    # When/then - internal address
    invalid_addresses.each do |invalid_address|
      assert_raise IPAddr::InvalidAddressError do
        ::Bcome::Node::Server::Static.new( { view_data: { identifier: "foo", internal_ip_address: invalid_address }})
      end
    end
  end

  # Test that IP address conforms
  # SSH to IPV6 address? : https://superuser.com/questions/236993/how-to-ssh-to-a-ipv6-ubuntu-in-a-lan
  # test parent is set

end
