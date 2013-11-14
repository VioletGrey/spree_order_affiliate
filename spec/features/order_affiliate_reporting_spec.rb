require 'spec_helper'

describe "Order Affiliate Reporting" do
  stub_authorization!
  let(:order) { create :order_with_line_items, line_items_count: 2 }

  describe "Affiliate Codes" do
    before :each do
      @code1 = Spree::AffiliateCode.create(code: 'rosie', rate: 0.05)
    end

    it "can create codes" do
      visit spree.admin_affiliate_codes_path
      fill_in 'affiliate_code_code', with: 'test'
      fill_in 'affiliate_code_rate', with: '0.05'
      click_button('Create Affiliate code')
      expect(page).to have_content('test')
      expect(page).to have_content('0.05')
    end

    it "can edit codes" do
      visit spree.edit_admin_affiliate_code_path(@code1)
      fill_in 'affiliate_code_code', with: 'test'
      click_button('Update Affiliate code')
      expect(page).to have_content('test')
    end
  end

  describe "Summary Reports" do
    before :each do
      @code1 = Spree::AffiliateCode.create(code: 'rosie', rate: 0.05)
      @code2 = Spree::AffiliateCode.create(code: 'eva', rate: 0.10)
      order.line_items.first.campaign_tag = 'rosie'
      order.line_items.first.save
      order.line_items.last.campaign_tag = 'eva'
      order.line_items.last.save
      order.state = 'complete'
      order.campaign_source = 'rosie'
      order.completed_at = Time.now
      order.save
    end

    context "Tag Report" do
      it "lists individual report for tags" do
        visit spree.tag_report_admin_affiliate_code_path(@code1)
        expect(page).to have_content('10.0')
        expect(page).to have_content('0.5')
      end

      it "should search by dates" do
        visit spree.tag_report_admin_affiliate_code_path(@code1)
        fill_in "q_created_at_gt", :with => Date.tomorrow
        click_icon :search
        expect(page).to_not have_content('10.0')
        expect(page).to have_content('0')
      end
    end

    context "SKU Report" do
      it "lists individual report for skus" do
        visit spree.sku_report_admin_affiliate_code_path(@code1)
        within('table.admin-report tbody') do
          column_text(2).should == "10.0"
          column_text(3).should == "1"
          column_text(4).should == "10.0"
          column_text(5).should == "0.5"
        end
      end

      it "should search by dates" do
        visit spree.sku_report_admin_affiliate_code_path(@code1)
        fill_in "q_created_at_gt", :with => Date.tomorrow
        click_icon :search
        expect(page).to_not have_content('10.0')
        expect(page).to have_content('0')
      end
    end

    context "Source Report" do
      it "lists individual report for source" do
        visit spree.admin_affiliate_code_path(@code1)
        expect(page).to have_content('2')
        expect(page).to have_content('20.0')
        expect(page).to have_content('1.0')
      end

      it "should search by dates" do
        visit spree.admin_affiliate_code_path(@code1)
        fill_in "q_created_at_gt", :with => Date.tomorrow
        click_icon :search
        expect(page).to_not have_content('20.0')
        expect(page).to have_content('0')
      end
    end

    context "Summary Source Report" do
      it "lists summary report for source" do
        visit spree.affiliate_source_report_admin_reports_path
        within('table.admin-report tbody') do
          column_text(1).should == "rosie"
          column_text(2).should == "1"
          column_text(3).should == "20.0"
          column_text(4).should == "1.0"
        end
      end

      it "should search by dates" do
        visit spree.affiliate_source_report_admin_reports_path
        fill_in "q_created_at_gt", :with => Date.tomorrow
        click_icon :search
        expect(page).to_not have_content('20.0')
        expect(page).to have_content('0')
      end
    end

    context "Summary Tag Report" do
      it "lists summary report for tags" do
        visit spree.affiliate_tag_report_admin_reports_path
        within('table.admin-report tbody') do
          column_text(1).should == "rosie"
          column_text(2).should == "1"
          column_text(3).should == "10.0"
          column_text(4).should == "0.5"
        end
      end

      it "should search by dates" do
        visit spree.affiliate_tag_report_admin_reports_path
        fill_in "q_created_at_gt", :with => Date.tomorrow
        click_icon :search
        expect(page).to_not have_content('20.0')
        expect(page).to have_content('0')
      end
    end
  end
end