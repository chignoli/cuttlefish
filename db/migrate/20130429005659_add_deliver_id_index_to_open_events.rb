# frozen_string_literal: true

class AddDeliverIdIndexToOpenEvents < ActiveRecord::Migration
  def change
    add_index :open_events, :delivery_id
  end
end
