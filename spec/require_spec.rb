require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/require_shared.rb'

shared_examples_for 'strict mode' do |method, fixture_method|
  context 'strict error mode' do
    context 'using global option' do
      def with_strict_mode
        RequireAll.strict_mode = true
        yield
      ensure
        RequireAll.strict_mode = false
      end

      it "can require resolvable dependencies when there are no errors raised" do
        with_strict_mode do
          fixture = send(fixture_method, 'resolvable_with_strict_mode/*.rb')
          send(method, fixture)
          is_expected.to be_loaded("A", "B", "C", "D")
        end
      end

      it "raises errors when they occur" do
        with_strict_mode do
          fixture = send(fixture_method, 'resolvable/*.rb')
          expect do
            send(method, fixture)
          end.to raise_error(NameError)
        end
      end
    end

    context 'using options on method call' do
      it "can require resolvable dependencies when there are no errors raised" do
        fixture = send(fixture_method, 'resolvable_with_strict_mode/*.rb')
        send(method, fixture, :strict_mode => true)
        is_expected.to be_loaded("A", "B", "C", "D")
      end

      it "raises errors when they occur" do
        fixture = send(fixture_method, 'resolvable/*.rb')
        expect do
          send(method, fixture, :strict_mode => true)
        end.to raise_error(NameError)
      end
    end
  end
end

describe "require_all" do

  subject { self }

  describe "dependency resolution" do
    it "handles load ordering when dependencies are resolvable" do
      require_all fixture_path('resolvable/*.rb')

      is_expected.to be_loaded("A", "B", "C", "D")
    end

    it "raises NameError if dependencies can't be resolved" do
      expect do
        require_all fixture_path('unresolvable/*.rb')
      end.to raise_error(NameError)
    end

    it_should_behave_like 'strict mode', :require_all, :fixture_path
  end

  before(:all) do
    @base_dir = fixture_path('autoloaded')
    @method = :require_all
  end
  it_should_behave_like "#require_all syntactic sugar"
end

describe "require_rel" do

  subject { self }

  it "provides require_all functionality relative to the current file" do
    require fixture_path('relative/b/b')

    is_expected.to be_loaded("RelativeA", "RelativeB", "RelativeC")
    is_expected.not_to be_loaded("RelativeD")
  end

  it_should_behave_like 'strict mode', :require_rel, :relative_fixture_path

  before(:all) do
    @base_dir = relative_fixture_path('autoloaded')
    @method = :require_rel
  end
  it_should_behave_like "#require_all syntactic sugar"
end
