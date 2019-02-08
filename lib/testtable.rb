require "testtable/version"
require 'rspec/core'

module Testtable
  RSpec::Matchers.define :be_the_same_table_as do |expected_file_name|
    match do |actual|
      @matches = []

      file_path = Rails.root.join("spec/fixtures/recorded_csvs/#{expected_file_name}.csv")

      if File.exist?(file_path)
        expected = CSV.parse(File.open(file_path), converters: :numeric)

        expected_titles = expected.first

        expected.each_with_index do |row, row_index|
          row.each_with_index do |cell, column_index|
            actual_value = actual[row_index][column_index]
            value_for_string = if row_index > 0
                                 "value for #{expected_titles[column_index]}"
                               else
                                 "value"
                               end

            if cell != actual_value
              @matches << [row_index, column_index, actual_value, value_for_string, cell]
            end
          end
        end
      else
        File.write(file_path, actual.map(&:to_csv).join)
      end

      @matches.empty?
    end

    failure_message do
      "Does not match #{expected_file_name}\n" +
          @matches.map do |match|
            row_index, column_index, actual_value, value_for_string, cell = match
            "Cell #{row_index}:#{column_index} (#{actual_value}) did not match expected #{value_for_string} (#{cell})."
          end.join("\n")
    end
  end
end
