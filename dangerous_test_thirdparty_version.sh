#!/usr/bin/env bash

# This test is dangerous in that it modifies the root rules_scala
# WORKSPACE file. It attempts to restore the existing WORKSPACE file
# but there are risks that it may not be successful.

# Hence when running this test one should be sure that they do not
# have changes in the WORKSPACE file which they cannot recover
# from if the file gets lost.

# Note that due to performance constraints this is purposely not
# part of CI but when modifying the dependency_analyzer plugin,
# this should be run to ensure no regressions.

set -e

replace_workspace() {
  sed -i '' \
      -e "s|scala_repositories(.*)|$1|" \
      $dir/WORKSPACE
}

test_scala_version() {
  SCALA_VERSION=$1

  SCALA_VERSION_SHAS=''
  SCALA_VERSION_SHAS+='"scala_compiler": "'$2'",'
  SCALA_VERSION_SHAS+='"scala_library": "'$3'",'
  SCALA_VERSION_SHAS+='"scala_reflect": "'$4'"'

  cp $dir/WORKSPACE $dir/WORKSPACE.bak
  replace_workspace "scala_repositories((\"$SCALA_VERSION\", { $SCALA_VERSION_SHAS }))"

  bazel test //third_party/...
  RESPONSE_CODE=$?
  # Restore old behavior
  rm $dir/WORKSPACE
  mv $dir/WORKSPACE.bak $dir/WORKSPACE
  exit $RESPONSE_CODE

}

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
test_dir=$dir/test/shell
# shellcheck source=./test_runner.sh
. "${test_dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")


# Latest versions of each major version

$runner test_scala_version "2.12.10" \
    "cedc3b9c39d215a9a3ffc0cc75a1d784b51e9edc7f13051a1b4ad5ae22cfbc0c" \
    "0a57044d10895f8d3dd66ad4286891f607169d948845ac51e17b4c1cf0ab569d" \
    "56b609e1bab9144fb51525bfa01ccd72028154fc40a58685a1e9adcbe7835730"


$runner test_scala_version "2.11.12" \
    "3e892546b72ab547cb77de4d840bcfd05c853e73390fed7370a8f19acb0735a0" \
    "0b3d6fd42958ee98715ba2ec5fe221f4ca1e694d7c981b0ae0cd68e97baf6dce" \
    "6ba385b450a6311a15c918cf8688b9af9327c6104f0ecbd35933cfcd3095fe04"


# Earliest functioning versions of each major version

$runner test_scala_version "2.12.0" \
    "c767f79f9c529cedba2805db910164d5846f1f6d02424c6d7aadfc42ae5dadf1" \
    "0e72ec4ea955d0bad7f1a494e8df95163f1631df0ce8ec4f9f278fe4d5fd1824" \
    "f56553934378e6d3e8bf1d759a51f8b2fc4c99370774f0aaedaab8619517ccbe"

$runner test_scala_version "2.11.9" \
    "fa01b414674cb38adc90ccf7a2042e82198dbb19dc41faccf0b5941ec08b1998" \
    "e435d5ef31cc12dbf66719b7d5ab677ad739c63c3e451757b9688dcbeda0a984" \
    "d932f809012d2cf832226b52a8bd82ed35b0257b1471c98968c0cd9ddf5327ab"

# Intermediate versions of 2.12.x

$runner test_scala_version "2.12.1" \
    "fdd7679ce8a3fb4e30fbb9eaf9451f42c042f5ac3b5497f0fd01c379a3df9b3f" \
    "9dab78f3f205a038f48183b2391f8a593235f794d8129a479e06af3e6bc50ef8" \
    "d8a2b9d6d78c7457a40e394dc0c4fa6d6244acf0d156bbbcb311a9d497b85eec"


$runner test_scala_version "2.12.2" \
    "b3d41a2887c114821878d45c1cb43cf7576c6854c7a303ef3d7be866dc44de34" \
    "dd668b609002b3578f2db83a1a684d706155bba2fc801cd411359fdd48218d00" \
    "98f9876d14b39fc7ec863c6b1b73c41a7653f886901b3ead0c4ca9215a688408"


$runner test_scala_version "2.12.3" \
    "99d28c90ef1b8569da76a7e04415184cc54b57221ee259ffc55b2fcd64fb2107" \
    "a8dd181a996dcc53a8c0bbb554bef7a1a9017ca09a377603167cf15444a85404" \
    "93db412846912a1c212dd83c36dd51aa0adb9f39bfa6c4c3d65682afc94366c4"


$runner test_scala_version "2.12.4" \
    "8b681302aac584f7234547eed04d2beeeb4a4f00032220e29d40943be6906a01" \
    "17824fcee4d3f46cfaa4da84ebad4f58496426c2b9bc9e341f812ab23a667d5d" \
    "ea70fe0e550e24d23fc52a18963b2be9c3b24283f4cb18b98327eb72746567cc"


$runner test_scala_version "2.12.5" \
    "a113394b6f857e69ef5d95b77114ec3f12cb0e14d9ede32de0bbc9c36d677455" \
    "c2636320d6479c82f2da6b8d76a820de9345a61327e648d4298a0048154fb87c" \
    "27036d7574afff72294f0e63d54aa13acd8b16b525d51475691118b835e626e7"


$runner test_scala_version "2.12.6" \
    "3023b07cc02f2b0217b2c04f8e636b396130b3a8544a8dfad498a19c3e57a863" \
    "f81d7144f0ce1b8123335b72ba39003c4be2870767aca15dd0888ba3dab65e98" \
    "ffa70d522fc9f9deec14358aa674e6dd75c9dfa39d4668ef15bb52f002ce99fa"


$runner test_scala_version "2.12.7" \
    "6e80ef4493127214d31631287a6789170bf6c9a771d6094acd8dc785e8970270" \
    "8f3dc6091db688464ad8b1ee6c7343d7aa5940d474ee8b90406c71e45dd74fc0" \
    "7427d7ee5771e8c36c1db5a09368fa3078f6eceb77d7c797a322a088c5dddb76"


$runner test_scala_version "2.12.8" \
    "f34e9119f45abd41e85b9e121ba19dd9288b3b4af7f7047e86dc70236708d170" \
    "321fb55685635c931eba4bc0d7668349da3f2c09aee2de93a70566066ff25c28" \
    "4d6405395c4599ce04cea08ba082339e3e42135de9aae2923c9f5367e957315a"


$runner test_scala_version "2.12.9" \
    "5fd556459fd189b820db7d7c0a644ea5f7e8e032c421f2ad47038e72247fbf65" \
    "364ee6ffd45f4fb8f9de40d1473d266ed5c199a44c1d4e2bdc895b1fbe35c75f" \
    "4285ba64044d1a62b19304fe3ddd0088da240649c9fe2a6571c989feda1d0829"


# Intermediate versions of 2.11.x


$runner test_scala_version "2.11.10" \
    "b70b748857213efe6f3a47d66acfa014c1bf51af3178b3a946eaae09f709fecc" \
    "14a520328ea4ca7f423b30154a54d3df0a531a9c51f5e98eda272c9821bc5331" \
    "fd896db4806875f538843ea24411e483ee4d0734710a108d0308ef108e83cf80"


$runner test_scala_version "2.11.11" \
    "5f929ed57c515ef9545497374eec88ffd129b8f04079dedb7e32107104325cdd" \
    "f2ba1550a39304e5d06caaddfa226cdf0a4cbccee189828fa8c1ddf1110c4872" \
    "73aef1a6ccabd3a3c15cc153ec846e12d0f045587a2a1d88cc1b49293f47cb20"

#######################
# These versions 2.11.0-2.11.8 do not work as
# it results in an error that argument -Ypartial-unification is invalid
# which is unrelated to the plugin.
#######################
#$runner test_scala_version "2.11.0" \
#    "d50dbbcc5fd79179fbe43c77560495c03c3193c38fc3ec9298802de67338d424" \
#    "3b19a2edb72292395182be38c864eda51432bed38496065ce51d2e466a97dfa6" \
#    "277af1255660f53cebd705b15badadff041a278f0d0c5bc5cfa3b1e03e9cabcf"

#$runner test_scala_version "2.11.1" \
#    "3aa616f5c56d2052fc5e3231f3e8cf1736f876caff0142a66096fc5b4dc87ae5" \
#    "088bcb80f71b6e6a2a31d2fe7288c1fd64f19663ce281b924cdfab3fb105f4f3" \
#    "41938d1e89670979dd783102777a8b879999f4fb00a5b811b51c105b02a9d4f8"


#$runner test_scala_version "2.11.2" \
#    "0a3101ad6b5a77a241f6e2931955c8c2dad3eb6c5c137b3b5cc26b25848e3bb0" \
#    "9810ab5cef1029a6c4341499ddb7dc7efe17f509fc7758df297653245f21b86c" \
#    "2afea573cc397fdb64d238e5d56c01c24ea876ce9205b01355257f7cf3a9bfd1"


#$runner test_scala_version "2.11.3" \
#    "c07722f66f14694a1d7b17fed89ddc176ddf71bb22d1b458650fd2a684a3700a" \
#    "8f95d76b4ac0906a71e23dc7754fee16026d6fa0563d74863f925ee3b91b8385" \
#    "d33cd9f6e9b8f30795bb149b1b716f6eb3253939dc4eb5f224164efcbb22fe15"


#$runner test_scala_version "2.11.4" \
#    "32e824d5b7926b45366b9159d8908c2f7f5763de8582ed28b5d22c32ff3142ca" \
#    "8aff9629606430369d596866f569659b146f00bd8ba838b59599d32bbaadbce2" \
#    "db9bf6d5fe692e6f055c02e5ffe751176cc03454b65bf8ae8eb1a7c5ffde2faa"


#$runner test_scala_version "2.11.5" \
#    "20bf5876c6eed99bc71cc4f1962cf5f2b779574a5f939504aaac19a2622ea0a8" \
#    "332d384e7c293626e10082be65c253372189488a1229757a1c765bdd677eb12e" \
#    "006babd84c821c6d8edf12c519697d92b01f22a04dcf12cadd3e8139d9458323"


#$runner test_scala_version "2.11.6" \
#    "83ee7242533556cd7ef815e312757a9938ec418e8dbcf3845c309de353411b4f" \
#    "b6fcb0f77a27587879fa30f6e4b9bf8bd872174416b9db893aa71a57e4713852" \
#    "6c37c744051a6e998fe494ac568746364b66b0f57b11298d1560b541e057d0c4"


#$runner test_scala_version "2.11.7" \
#    "23a7eeefc043ef4846dfd08a66b0dfd60106bfc093e17c16e3c39183f146632f" \
#    "b401e1dc0ab03370f4e6078dbc8b8eb478c7cdf97022c13bab61baad21e98158" \
#    "8cb825e246d2c7b0cc1a8005e34352132b6018eeb54cf35d24719a29b3885fd2"


#$runner test_scala_version "2.11.8" \
#    "3271d4aaea158fed5184f7fce734cb23786d923f064f941881710d90b99aac27" \
#    "401e0f47d63221c811964534f2e480169f50919c804f728930ac6037eca4e5f6" \
#    "29e081446a2a35de867411e06c6bc86863ac802401f8e8826f87723f668b4319"
