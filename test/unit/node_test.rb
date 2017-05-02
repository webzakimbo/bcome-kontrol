load "#{File.dirname(__FILE__)}/../base.rb"

class NodeTest < ActiveSupport::TestCase

  include ::UnitTestHelper

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
    ::Bcome::Node::Base.expects(:init_tree).returns(estate)    

    # When
    init_estate = ::Bcome::Node::Base.init_tree

    # Then
    assert init_estate == estate
  end

  def test_should_be_able_to_load_a_resource_by_identifier
    # Given
    estate = given_a_dummy_estate
    view_data = given_dummy_view_data  # one:two:three:four
    ::Bcome::Node::Base.create_tree(estate,view_data)

    third_context = test_traverse_tree(estate, ["one", "two", "three"])
    fourth_context = test_traverse_tree(estate, ["one", "two", "three", "four"])

    # When/then
    assert fourth_context = third_context.resource_for_identifier("four")

    # And also that
    assert fourth_context.parent == third_context
  end


  def test_should_construct_network_with_network_data
    # Given
    collection = given_a_dummy_collection
    network_data = {}
    mocked_network_driver = mock("I'm a network driver")

    collection.expects(:network_data).returns(network_data)
    ::Bcome::Driver::Base.expects(:create_from_config).with(network_data).returns(mocked_network_driver)

    # when/then ... all our expectations are met
    network_driver_from_estate = collection.network_driver

    # and also that
    assert network_driver_from_estate == mocked_network_driver  
  end

  def test_nodes_should_inherit_network_driver_data_from_parents
    [
      [:network, :network_data],
      [:ec2_filters, :filters]
    ].each do |inheritable_attributes|
       view_key = inheritable_attributes[0]
       node_key = inheritable_attributes[1]
       nodes_should_inherit_network_config_data_from_parents(view_key, node_key) 
       nodes_should_inherit_from_above_only_what_they_do_not_define_and_thus_override_themselves(view_key, node_key)
     end
  end

  def nodes_should_inherit_network_config_data_from_parents(view_key, node_key)
    # Given view data with tested configuration at the top level only
    col1_network_data = { :foo => "foo", :bar => "bar" }
    view_data = [
      { view_key => col1_network_data, :type => "collection", :identifier => "one", :description => "desc1", :views => [
        { :type => "collection", :identifier => "two", :description => "desc1", :views => [
          { :type => "collection", :identifier => "three", :description => "desc1" } # end col3  
        ] } # end col2     
      ] } # end col1
    ]

    # And given an estate with a generated tree structure
    estate = given_a_dummy_estate
    ::Bcome::Node::Base.create_tree(estate, view_data)

    # And the resultant nodes
    nodes = all_nodes_in_tree(estate, ["one", "two", "three"]) 
    col1 = nodes[0]
    col2 = nodes[1]
    col3 = nodes[2]

    # When/then all nodes should have the same dataa
    nodes.each do |node|
      assert node.send(node_key) == col1_network_data
    end
  end

  def nodes_should_inherit_from_above_only_what_they_do_not_define_and_thus_override_themselves(view_key, node_key)
    # Given
    view_data = [
      { view_key => { :foo => :bar, :moo => :woo }, :type => "collection", :identifier => "one", :description => "desc1", :views => [
        { :type => "collection", :identifier => "two", :description => "desc1", :views => [
          { view_key => {:foo => :some_other_value }, :type => "collection", :identifier => "three", :description => "desc1" } # end col3  
        ] } # end col2     
      ] } # end col1
    ]

    # And given an estate with a generated tree structure
    estate = given_a_dummy_estate
    ::Bcome::Node::Base.create_tree(estate, view_data)

    # And the resultant nodes
    nodes = all_nodes_in_tree(estate, ["one", "two", "three"])             
    col1 = nodes[0]
    col2 = nodes[1]
    col3 = nodes[2]

    # When/then
    assert col1.send(node_key) == { :foo => :bar, :moo => :woo }
    assert col2.send(node_key) == col1.send(node_key)
    assert col3.send(node_key) == { :foo => :some_other_value, :moo => :woo }

    ### AND then also
    # Given
    view_data = [
      { view_key => { :foo => :bar, :moo => :woo }, :type => "collection", :identifier => "one", :description => "desc1", :views => [
        { view_key => { :do => :yes, :moo => :something_else_again }, :type => "collection", :identifier => "two", :description => "desc1", :views => [
          { view_key => {:foo => :some_other_value, :loo => "something else entirely" }, :type => "collection", :identifier => "three", :description => "desc1" } # end col3  
        ] } # end col2     
      ] } # end col1
    ]

    # And given an estate with a generated tree structure
    estate = given_a_dummy_estate
    ::Bcome::Node::Base.create_tree(estate,view_data)

    # And the resultant nodes
    nodes = all_nodes_in_tree(estate, ["one", "two", "three"])
    col1 = nodes[0]
    col2 = nodes[1]
    col3 = nodes[2]

    # When/then
    assert col1.send(node_key) == { :foo => :bar, :moo => :woo }
    assert col2.send(node_key) == { :do => :yes, :foo => :bar, :moo => :something_else_again }
    assert col3.send(node_key) == { :do => :yes, :foo => :some_other_value, :moo => :something_else_again, :loo => "something else entirely" }
  end

end
