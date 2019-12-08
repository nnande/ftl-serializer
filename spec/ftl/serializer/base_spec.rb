# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FTL::Serializer::Base do

  before do
    class Test::Patient < Struct.new(:id, :first_name, :last_name, :updated_at); end
    class Test::Store < Struct.new(:id, :name, :updated_at); end
  end

  context "dsl" do
    describe 'format' do
      it 'can return the format in camelCase' do
        patient = Test::Patient.new(1, "Dave")

        subject = FTL::TestExamples::BasicSerializer::WithCamelCase.new(patient).root(:important_patient)

        expect(subject.to_h).to eq("importantPatient" => { "firstName" => "Dave" })
      end

      it 'defaults to snake_case' do
        patient = Test::Patient.new(1, "Dave")

        subject = FTL::TestExamples::BasicSerializer.new(patient)

        expect(subject.to_h).to eq("first_name" => "Dave")
      end
    end

    describe "root" do
      it 'can add a root to the hash' do
        patient = Test::Patient.new(1, "Dave")

        subject = FTL::TestExamples::BasicSerializer::WithRoot.new(patient)

        expect(subject.to_h).to eq("my_root" => { "first_name" => "Dave" })
      end

      it "should pluralize the root name with a collection" do
        patients = [
          Test::Patient.new(1, "Dave"),
          Test::Patient.new(2, "Pete")
        ]

        subject = FTL::TestExamples::BasicSerializer::WithRoot.new(patients)

        expect(subject.to_h).to eq("my_roots" => [{ "first_name" => "Dave" }, { "first_name" => "Pete" }])
      end

      it "can override a root name when initializing" do
        patients = [
          Test::Patient.new(1, "Dave"),
          Test::Patient.new(2, "Pete")
        ]

        subject = FTL::TestExamples::BasicSerializer::WithRoot.new(patients).root(:ovverrided)

        expect(subject.to_h).to eq("ovverrideds" => [{ "first_name" => "Dave" }, { "first_name" => "Pete" }])
      end

      it "can disable a root when initializing" do
        patients = [
          Test::Patient.new(1, "Dave"),
          Test::Patient.new(2, "Pete")
        ]

        subject = FTL::TestExamples::BasicSerializer::WithRoot.new(patients).root(:disabled)

        expect(subject.to_h).to eq([{ "first_name" => "Dave" }, { "first_name" => "Pete" }])
      end
    end

    describe "meta" do
      it 'should be able to append something to your json' do
        patients = [
            Test::Patient.new(1, "Dave"),
            Test::Patient.new(2, "Pete")
          ]

        subject = FTL::TestExamples::BasicSerializer::WithRoot.new(patients).meta("some" => "hash")

        expect(subject.to_h).to eq(
          "my_roots" =>
            [
              { "first_name" => "Dave" },
              { "first_name" => "Pete" }
            ],
            "meta" => { "some" => "hash" }
        )
      end

      it 'can add keys to meta or links' do
        patients = [
            Test::Patient.new(1, "Dave"),
            Test::Patient.new(2, "Pete")
          ]

        subject = FTL::TestExamples::BasicSerializer::WithRoot.new(patients).meta("some" => "hash").links("another" => "hash")

        expect(subject.to_h).to eq(
          "my_roots" =>
            [
              { "first_name" => "Dave" },
              { "first_name" => "Pete" }
            ],
            "meta" => { "some" => "hash" },
            "links" => { "another" => "hash" }
        )
      end

      it 'is ignored for a single resource' do
        patient = Test::Patient.new(1, "Dave")

        subject = FTL::TestExamples::BasicSerializer::WithRoot.new(patient).meta("some" => "hash")

        expect(subject.to_h).to eq("my_root" => { "first_name" => "Dave" })
      end

      it 'is ignored if there is no root_key' do
        patients = [
            Test::Patient.new(1, "Dave"),
            Test::Patient.new(2, "Pete")
          ]

        subject = FTL::TestExamples::BasicSerializer.new(patients).meta("some" => "hash")

        expect(subject.to_h).to eq([{ "first_name" => "Dave" }, { "first_name" => "Pete" }])
      end
    end

    describe "locals" do
      it "allows you to chain in locals" do
        patient = Test::Patient.new(1, "Dave")
        store = Test::Store.new(1, "Test::Store Name")

        subject = FTL::TestExamples::BasicSerializer::WithLocals.new(patient).locals(current_store: store)

        expect(subject.to_h).to eq("first_name" => "Dave", "store_name" => "Test::Store Name")
      end

      it "also allows you to add in locals as an args hash" do
        patient = Test::Patient.new(1, "Dave")
        store = Test::Store.new(1, "Test::Store Name")

        subject = FTL::TestExamples::BasicSerializer::WithLocals.new(patient, locals: { current_store: store })

        expect(subject.to_h).to eq("first_name" => "Dave", "store_name" => "Test::Store Name")
      end

      it 'can call .locals on a serializer to get a struct of the local object that was passed in' do
        patient = Test::Patient.new(1, "Dave")
        store = Test::Store.new(1, "Test::Store Name")

        subject = FTL::TestExamples::BasicSerializer::WithLocals.new(patient).locals(current_store: store).locals

        expect(subject.is_a?(Struct)).to eq(true)
        expect(subject.current_store.name).to eq("Test::Store Name")
      end

      it 'can take multiple locals' do
        patient = Test::Patient.new(1, "Dave")
        store = Test::Store.new(1, "Test::Store Name")
        another_store = Test::Store.new(1, "Another Test::Store")

        subject = FTL::TestExamples::BasicSerializer.new(patient)
                                 .locals(my_store: store, my_other_store: another_store)
                                 .locals

        expect(subject.my_store.name).to eq('Test::Store Name')
        expect(subject.my_other_store.name).to eq('Another Test::Store')
      end

      it "should be nil if locals aren't passed in" do
        patient = Test::Patient.new(1, "Dave")

        subject = FTL::TestExamples::BasicSerializer::WithLocals.new(patient)

        expect(subject.locals).to be_nil
      end

      it "should throw an error if you pass in locals that aren't a hash" do
        patient = Test::Patient.new(1, nil, nil, Time.parse("2018-05-29 19:13:30"))

        subject = FTL::TestExamples::BasicSerializer::WithLocals.new(patient).locals("not_a_hash")

        expect { subject.to_h }.to raise_error(FTL::Errors::LocalsError)
      end
    end

    describe "merge_with" do
      it 'allows you to merge in any other serializer' do
        patient = Test::Patient.new(1, "Dave", "Considine")

        subject = FTL::TestExamples::BasicSerializer::WithMerge.new(patient)

        expect(subject.to_h).to eq("first_name" => "Dave", "last_name" => "Considine")
      end
    end
  end

  context "serialization" do
    describe ".to_h" do
      it 'should serialize a singular object' do
        patient = Test::Patient.new(1, "Dave")

        expect(FTL::TestExamples::BasicSerializer.new(patient).to_h).to eq("first_name" => "Dave")
      end

      it 'should be able to serialize a collection' do
        patients = [
          Test::Patient.new(1, "Dave"),
          Test::Patient.new(2, "Pete")
        ]

        expect(FTL::TestExamples::BasicSerializer.new(patients).to_h).to eq([{ "first_name" => "Dave" }, { "first_name" => "Pete" }])
      end

      it 'should be able to inherit behaviour from another serializer' do
        patient = Test::Patient.new(1, "Dave", "Grohl")

        expect(FTL::TestExamples::BasicSerializer::Inherited.new(patient).to_h).to eq("first_name" => "Dave", "last_name" => "Grohl")
      end
    end

    describe ".to_json" do
      it 'converts the hash to json' do
        patient = Test::Patient.new(1, "Rosa")

        expect(FTL::TestExamples::BasicSerializer.new(patient).to_json).to eq("{\"first_name\":\"Rosa\"}")
      end
    end
  end
end
