# frozen_string_literal: true

class AddHeadNumberToOptionsTable < ActiveRecord::Migration[7.0]
  def change
    # Survey Options table
    add_column :survey_options, :head_number, :string
  end
end
