load "#{File.dirname(__FILE__)}/../base.rb"

class NodeTest < ActiveSupport::TestCase

  def test_should_initialize_node
    # Given
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

    # when
    node = Bcome::Node::Base.new(params)

    # Then
    assert node.is_a?(Bcome::Node::Base)
    assert node.identifier == identifier
    assert node.description == description
    assert node.type == type
  end   

  def test_ad_hoc_attributes_are_set
    # Given
    params = given_estate_setup_params

    # Given a random attribute set to a random value
    random_attribute = given_a_random_string_of_length(10)
    random_value = given_a_random_string_of_length(10)
    params[:view_data][random_attribute] = random_value

    # When
    node = Bcome::Node::Base.new(params)

    # Then
    assert node.send(random_attribute) == random_value    
  end

  def test_description_is_required
    # Given
    params = given_estate_setup_params
    params[:view_data].delete(:description)

    # When/then
    assert_raise Bcome::Exception::MissingDescriptionOnView do
      Bcome::Node::Base.new(params)
    end
  end

  def test_identifier_is_required
    # Given
    params = given_estate_setup_params
    params[:view_data].delete(:identifier)

    # When/then
    assert_raise Bcome::Exception::MissingIdentifierOnView do
      Bcome::Node::Base.new(params)
    end
  end

  def test_type_is_required
    params = given_estate_setup_params
    params[:view_data].delete(:type)

    # When/then
    assert_raise Bcome::Exception::MissingTypeOnView do
      Bcome::Node::Base.new(params)
    end
  end

  def test_init_estate
    # Given
    estate = Bcome::Node::Base.new(given_estate_setup_params)
    ::Bcome::Node::Estate.expects(:init_tree).returns(estate)    

    # When
    init_estate = ::Bcome::Node::Estate.init_tree

    # Then
    assert init_estate == estate
  end

end
