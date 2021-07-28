require 'test_helper'

# Tests behaviour of the `HasManyReferers` concern.
class HasManyReferersTest < ActiveSupport::TestCase
  def setup
    @resource = projects(:dummy_project)
  end

  test 'should have many referrers' do
    assert @resource.class.reflect_on_association(:referent_contracts)
    assert @resource.class.reflect_on_association(:referent_releases)
    assert @resource.class.reflect_on_association(:referent_dpias)

    assert_instance_of ::Contract, @resource.referent_contracts.build
    assert_instance_of ::Release,  @resource.referent_releases.build
    assert_instance_of ::DataPrivacyImpactAssessment, @resource.referent_dpias.build
  end
end
