######################################################################
#<
#
# Function: p6df::modules::p6test::version()
#
#>
######################################################################
p6df::modules::p6test::version()        { echo "0.2.1" }
######################################################################
#<
#
# Function: p6df::modules::p6test::init()
#
#>
######################################################################
p6df::modules::p6test::init() {

  local dir="$P6_DFZ_SRC_DIR/p6m7g8/p6test"

  . $dir/lib/_bootstrap.sh
  p6_p6test_bootstrap "$dir"
}