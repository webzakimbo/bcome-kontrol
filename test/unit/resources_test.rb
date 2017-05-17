load "#{File.dirname(__FILE__)}/../base.rb"

class ResourcesTest < ActiveSupport::TestCase
  include UnitTestHelper


  def test_should_be_to_create_resources
    # Given
    identifier = "foo"
    description = "bar"
    estate = Bcome::Node::Collection.new(view_data: { identifier: identifier, description: description, type: 'inventory' })

    # then
    assert estate.resources.size == 0
    assert estate.resources.empty?

    resources = []
    number_of_resources = rand(10)

    number_of_resources.times do |i|
      resource = mock("Resource node #{i}")
      resource.expects(:identifier).returns(given_a_random_string_of_length(4)).at_least_once
      resources << resource
      # When
      estate.resources << resource
    end

    # Then
    assert estate.resources.size == resources.size
    assert estate.resources.first == resources.first

    # And also that
    estate.resources.each_with_index do |resource, i|
      assert resource == resources[i]
    end

    # And also that
    estate.resources.active == resources
  end

  def test_should_ensure_that_resources_have_unique_identifiers
    # Given
    identifier = "foo"
    description = "bar"
    estate = Bcome::Node::Collection.new(view_data: { identifier: identifier, description: description, type: 'inventory' })

    resource_1 = mock("Resource 1")
    resource_1_identifier = given_a_random_string_of_length(3)
    resource_1.expects(:identifier).returns(resource_1_identifier).at_least_once

    resource_2 = mock("Resource 2")
    resource_2.expects(:parent).returns(estate)
    resource_2.expects(:identifier).returns(resource_1_identifier).at_least_once

    estate.resources << resource_1

    # When/then
    assert_raise Bcome::Exception::NodeIdentifiersMustBeUnique do
      estate.resources << resource_2
    end
  end

  def add_mocked_resource_to_estate(estate)
    resource = mock("Mocked resource #{given_a_random_string_of_length(5)}")
    resource.expects(:identifier).returns(given_a_random_string_of_length(3)).at_least_once
    estate.resources << resource
    resource
  end

  def test_should_be_able_to_disable_and_enable_resources
    # Given
    identifier = "foo"
    description = "bar"
    estate = Bcome::Node::Collection.new(view_data: { identifier: identifier, description: description, type: 'inventory' })

    resources = []
    10.times do |i|
      resource = add_mocked_resource_to_estate(estate)
      resources << resource
    end

    # Sanity
    assert estate.resources.active == resources

    # When we disable resources
    estate.resources.do_disable(resources[1].identifier)
    estate.resources.do_disable(resources[2].identifier)
    estate.resources.do_disable(resources[3].identifier)

    # Then they are disabled
    active_resources = resources - [resources[1], resources[2], resources[3]]
    assert estate.resources.active == active_resources
    
    # And also that
    [resources[1], resources[2], resources[3]].each do |inactive_resource|
      assert !estate.resources.is_active_resource?(inactive_resource)
    end

    # When we enable resources
    estate.resources.do_enable(resources[1].identifier)

    # Then
    active_resources = resources - [resources[2], resources[3]]
    assert estate.resources.active == active_resources

    # When we clear disabled resources
    estate.resources.clear!

    # Then, all our restources are active
    assert estate.resources.active == resources

    # When we disable all resources
    estate.resources.disable!

    # Then
    assert estate.resources.active == []
  end

end
