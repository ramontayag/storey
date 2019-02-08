require "spec_helper"

module Storey
  RSpec.describe RackSwitch do

    let(:env) do
      { "env" => "here" }
    end

    context "processor returns nil" do
      let(:processor) { ->(env) { nil } }
      before do
        Storey.create("original_schema")
        Storey.switch("original_schema")
      end

      it "does not switch and continues with the next rack app" do
        schema_in_app = nil
        app = ->(env) { schema_in_app = Storey.schema }

        expect(processor).to receive(:call).with(env).
          and_call_original

        switch = described_class.new(app, processor)
        switch.(env)

        expect(schema_in_app).to eq "original_schema"
      end
    end

    context "processor returns a string" do
      let(:processor) { ->(env) { "tenant" } }
      before do
        Storey.create("tenant")
      end

      it "switches to the string returned by the processor" do
        schema_in_app = nil
        app = ->(env) { schema_in_app = Storey.schema }

        expect(processor).to receive(:call).with(env).
          and_call_original

        switch = described_class.new(app, processor)
        switch.(env)

        expect(schema_in_app).to eq "tenant"
      end
    end
  end
end
