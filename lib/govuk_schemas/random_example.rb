require "govuk_schemas/random"
require "govuk_schemas/random_item_generator"
require "json-schema"
require "json"

module GovukSchemas
  class RandomExample
    # TODO: add docs
    def initialize(schema:)
      @schema = schema
      @random_generator = RandomItemGenerator.new(schema: schema)
    end

    # TODO: add docs
    def self.for_schema(schema_name, schema_type:)
      schema = GovukSchemas::Schema.find(schema_name, schema_type: schema_type)
      GovukSchemas::RandomExample.new(schema: schema)
    end

    # TODO: add docs
    def payload
      item = @random_generator.payload
      errors = validation_errors_for(item)

      if errors.any?
        raise InvalidContentGenerated, error_message(item, errors)
      end

      item
    end

    # TODO: add docs
    def merge_and_validate(hash)
      item = payload.merge(Utils.stringify_keys(hash))
      errors = validation_errors_for(item)

      if errors.any?
        raise InvalidContentGenerated, error_message_custom(item, errors)
      end

      item
    end

  private

    def validation_errors_for(item)
      JSON::Validator.fully_validate(@schema, item, errors_as_objects: true)
    end

    def error_message(item, errors)
      <<err
An invalid content item was generated by `RandomExample`. This probably
means that either you've merged the content item with invalid values, or there's
a bug in the generator that causes it to output invalid values. Below you'll find
the generated payload, the validation errors and the schema that was used.
Together these should be sufficient to debug the issue.

Errors:
--------------------------

#{JSON.pretty_generate(errors)}

Generated payload:
--------------------------

#{JSON.pretty_generate([item])}

Schema:
--------------------------

#{JSON.pretty_generate(@schema)}
err
    end

    def error_message_custom(item, errors)
      <<err
An invalid content item was generated by `RandomExample`. This probably
means you've merged the content item with invalid values.

Errors:
--------------------------

#{JSON.pretty_generate(errors)}

Generated payload:
--------------------------

#{JSON.pretty_generate([item])}

Schema:
--------------------------

#{JSON.pretty_generate(@schema)}
err
    end
  end
end
