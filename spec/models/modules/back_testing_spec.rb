require "rails_helper"

module My
  class ValidKlass
    include Modules::BackTesting

    def back_test_risk_pct
      0.3
    end

    def back_test_commission_pct
      3.6
    end

    def symbols
      ["AUDCAD", "EURJPY"]
    end

    def back_test?
      true
    end

    def back_test_start_date
      DateTime.parse("2020-02-03")
    end

    def back_test_end_date
      DateTime.parse("2020-02-04")
    end
  end
end

module My
  class InvalidKlass
    include Modules::BackTesting

    def back_test?
      false
    end
  end
end

describe Modules::BackTesting do
  let(:instance) { My::ValidKlass.new }

  describe "#back_test" do
    subject(:back_test) { instance.back_test }


    it "will create a back test record in the database" do
      expect { back_test }.to change { BackTest.count }.from(0).to(1)
    end

    describe "fields" do
      before do
        back_test
      end

      it "will use the correct class name" do
        expect(BackTest.last.strategy_class).to eq "ValidKlass"
      end

      it "will use the correct class risk_pct" do
        expect(BackTest.last.risk_pct).to be 0.3
      end

      it "will use the correct class commission_pct" do
        expect(BackTest.last.commission_pct).to be 3.6
      end

      it "will use the correct symbols" do
        expect(BackTest.last.symbols).to eq ["AUDCAD", "EURJPY"]
      end
    end

    context "this class including the module is not a back test" do
      let(:instance) { My::InvalidKlass.new }

      it "will raise an error" do
        expect { back_test }.to raise_error(Modules::BackTesting::NotBackTestError)
      end
    end
  end
end