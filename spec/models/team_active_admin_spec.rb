require 'rails_helper'

RSpec.describe "Team ActiveAdmin Integration", type: :model do
  describe "ActiveAdmin configuration" do
    let(:teams_rb_content) { File.read(Rails.root.join('app/admin/teams.rb')) }

    it "registers Team as a resource" do
      expect(teams_rb_content).to include('ActiveAdmin.register Team do')
    end

    it "permits only name and max_members attributes" do
      expect(teams_rb_content).to include('permit_params :name, :max_members')
      expect(teams_rb_content).not_to include(':admin_id')
    end

    it "excludes destroy action" do
      expect(teams_rb_content).to include('actions :all, except: [:destroy]')
    end
  end
end 