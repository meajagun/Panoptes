require 'spec_helper'

RSpec.describe Aggregation, :type => :model do
  let(:aggregation) { build(:aggregation) }

  it 'should have a valid factory' do
    expect(aggregation).to be_valid
  end

  it 'should not be valid without an aggregation hash' do
    expect(build(:aggregation, aggregation: nil)).to_not be_valid
  end

  it 'should not be valid without a workflow' do
    expect(build(:aggregation, workflow: nil)).to_not be_valid
  end

  it 'should not be valid without a subject' do
    expect(build(:aggregation, subject: nil)).to_not be_valid
  end

  context "when missing the workflow_version aggregation metadata" do
    let(:no_workflow_version) { build(:aggregation, aggregation: { test: 1}) }

    it 'should not be valid' do
      expect(no_workflow_version).to_not be_valid
    end

    it 'should not have the correct error message' do
      no_workflow_version.valid?
      error_message = "must have workflow_version metadata"
      expect(no_workflow_version.errors[:aggregation]).to include(error_message)
    end
  end

  context "when there is a duplicate subject_id workflow_id entry" do
    before(:each) do
      aggregation.save
    end
    let(:duplicate) do
      build(:aggregation, workflow: aggregation.workflow,
                          subject: aggregation.subject)
    end

    it "should not be valid" do
      expect(duplicate).to_not be_valid
    end

    it "should have the correct error message on subject_id" do
      duplicate.valid?
      expect(duplicate.errors[:subject_id]).to include("has already been taken")
    end

    it "should raise a uniq index db error" do
      expect{duplicate.save(validate: false)}.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
