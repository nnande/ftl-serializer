# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FTL::Serializer do
  before do
    $previous_serializer_values = FTL::Serializer.instance_eval { @serializers }
  end

  after do
    FTL::Serializer.instance_eval { @serializers = $previous_serializer_values }
  end

  describe ".register_serializer" do
    it 'should be be able register a serializer class' do
      FTL::Serializer.register_serializer(FTL::TestExamples::BasicSerializer)

      expect(FTL::Serializer.instance_eval { @serializers }).to include(FTL::TestExamples::BasicSerializer)
    end

    it 'should not add duplicates' do
      FTL::Serializer.register_serializer(FTL::TestExamples::BasicSerializer)
      FTL::Serializer.register_serializer(FTL::TestExamples::BasicSerializer)

      serializer_count = FTL::Serializer.instance_eval { @serializers.select { |s| s == FTL::TestExamples::BasicSerializer }.count }

      expect(serializer_count).to eq(1)
    end
  end

  describe ".registered_serializers" do
    it 'should list all of the registered serializers that have been loaded' do
      subject = FTL::Serializer.instance_eval { @serializers }

      expect(FTL::Serializer.registered_serializers).to eq(subject)
    end
  end

  describe ".bootstrap!" do
    it 'should return nil if no serializers are defined' do
      FTL::Serializer.instance_eval { @serializers = nil }

      FTL::Serializer.bootstrap!

      expect(FTL::Serializer.instance_eval { @serializers }).to eq(nil)
    end

    it 'should send a message to the serializer to define its hash structure' do
      class NewSerializer < FTL::Serializer::Base
        attributes :last_name
      end
      allow(NewSerializer).to receive(:define_to_h).and_return(instance_spy(NewSerializer))

      FTL::Serializer.bootstrap!

      expect(NewSerializer).to have_received(:define_to_h)

      FTL::Serializer.instance_eval { @serializers.delete(NewSerializer) }
    end
  end
end
