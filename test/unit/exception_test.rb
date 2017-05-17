load "#{File.dirname(__FILE__)}/../base.rb"

class ExceptionTest < ActiveSupport::TestCase
  def test_exception_creation
    # Given
    message = 'something has gone wrong'

    # When
    exception = ::Bcome::Exception::InvalidProxyConfig.new(message)

    # Then
    assert exception.is_a?(::Bcome::Exception::InvalidProxyConfig)
    assert exception.is_a?(::Bcome::Exception::Base)

    # And also that
    begin
      raise exception
    rescue ::Bcome::Exception::Base
      # That we are able to catch the exception
    end
  end
end
