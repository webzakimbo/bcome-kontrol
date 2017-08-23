load "#{File.dirname(__FILE__)}/../base.rb"

class RegistryArgumentsTest < ActiveSupport::TestCase
  include UnitTestHelper

   #["foo=bar", "moo=woo"]  command line
   #{:build=>"master"}    defaults

  def test_should_be_able_to_create_a_command_line_arguments_processor
    # Given
    arguments = ["foo=other"]
    defaults = { :foo => :bar, :moo => :woo }
 
    # When
    processor = Bcome::Registry::Arguments::CommandLine.new(arguments, defaults)

    # Then
    assert processor.is_a?(Bcome::Registry::Arguments::CommandLine)
    assert processor.arguments == arguments
    assert processor.defaults == defaults
  end

  def test_should_default_args_and_defaults_to_empty_arrays_where_non_provided
    # Given
    arguments = nil
    defaults = nil

    # When
    processor = Bcome::Registry::Arguments::CommandLine.new(arguments, defaults)

    # Then
    assert processor.arguments == []
    assert processor.defaults == {}
  end

  def test_should_assert_data_types_for_console
    # Given
    arguments = :not_a_hash

    # When/Then
    assert_raise ::Bcome::Exception::InvalidRegistryArgumentType do
      Bcome::Registry::Arguments::Console.new(arguments, nil)
    end  
  end


  def test_should_assert_data_types_for_command_line
    # Given
    arguments = :not_an_array
 
    # When/then
    assert_raise ::Bcome::Exception::InvalidRegistryArgumentType do
      Bcome::Registry::Arguments::CommandLine.new(arguments, nil)
    end

    # Given
    defaults = :not_a_hash

    # When/then
    assert_raise ::Bcome::Exception::InvalidRegistryArgumentType do
      Bcome::Registry::Arguments::CommandLine.new(defaults, nil)
    end
  end

  def test_user_supplied_arguments_are_parsed_correctly_for_command_line
    # Given
    arguments = ["foo=bar", "woo=other"]
    processor = Bcome::Registry::Arguments::CommandLine.new(arguments, nil)
   
    # When
    processor.do_process

    # Then
    assert processor.processed_arguments == { :foo => "bar", :woo => "other" }
  end

  def test_should_reject_malformed_arguments
    # Given
    some_malformed_arguments = [
      ["malformed"],
      ["also=", "malformed"],
      ["and", "=this"]
    ] 

    # When
    some_malformed_arguments.each do |malformed_arguments|
      processor = Bcome::Registry::Arguments::CommandLine.new(malformed_arguments, nil)
      assert_raise Bcome::Exception::MalformedCommandLineArguments do
        processor.do_process
      end 
    end
  end

  def test_should_reject_duplicate_argument_keys
    # Given
    arguments = ["foo=bar", "woo=moo", "foo=moo"]
    processor = Bcome::Registry::Arguments::CommandLine.new(arguments, nil)

    # when/then
    assert_raise Bcome::Exception::DuplicateCommandLineArgumentKey do
      processor.do_process
    end
  end  

  def test_should_merge_in_user_arguments_with_defaults_for_command_line
    # Given
    arguments = ["foo=bar"]
    defaults = { :moo => "woo" }
    processor = Bcome::Registry::Arguments::CommandLine.new(arguments, defaults)
  
    # When
    processor.do_process

    # Then
    assert processor.merged_arguments == { :foo => "bar", :moo => "woo" } 
  end

  def test_should_merge_in_user_arguments_with_defaults_for_console
    # Given
    arguments = { :foo => "bar" }
    defaults = { :moo => "woo" }
    processor = Bcome::Registry::Arguments::Console.new(arguments, defaults)
  
    # When
    processor.do_process

    # Then
    assert processor.merged_arguments == { :foo => "bar", :moo => "woo" }
  end

  def test_that_for_console_input_all_arguments_have_their_keys_coerced_to_symbols
    # Given
    arguments = { "key" => "value" }
    defaults = { "anotherkey" => "value" } 
    processor = Bcome::Registry::Arguments::Console.new(arguments, defaults)
   
    # when 
    processor.do_process 

    # Then
    assert processor.merged_arguments == { :key => "value", :anotherkey => "value" }
  end

  def user_supplied_arguments_should_take_precendence_over_defaults
    # Given
    arguments = ["foo=bar"]
    defaults = { :foo => :something_else }
    processor = Bcome::Registry::Arguments::CommandLine.new(arguments, defaults)

    # When
    processor.do_process

    # Then
    assert processor.merged_arguments = { :foo => "bar" }
  end

  def test_class_accessor_wiring_for_command_line
    # Given
    arguments = mock("Arguments")
    defaults = mock("Defaults")
    command_line_processor = mock("Command line processor") 
    whatever = mock("we don't care what this is, we're just testing wiring")

    ::Bcome::Registry::Arguments::CommandLine.expects(:new).with(arguments, defaults).returns(command_line_processor)
    command_line_processor.expects(:do_process).returns(whatever)
   
    # When/then
    ::Bcome::Registry::Arguments::CommandLine.process(arguments, defaults)
  end

  def test_class_accessor_wiring_for_console
    arguments = mock("Arguments")
    defaults = mock("Defaults")
    console_processor = mock("console line processor")       
    whatever = mock("we don't care what this is, we're just testing wiring")

    ::Bcome::Registry::Arguments::Console.expects(:new).with(arguments, defaults).returns(console_processor)
    console_processor.expects(:do_process).returns(whatever)
   
    # When/then
    ::Bcome::Registry::Arguments::Console.process(arguments, defaults)
  end

end
