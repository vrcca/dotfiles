function update_java_home
  set current (asdf current java)
  if test "$current" = "" then
    echo "No java version set. Type `asdf list-all java` for all versions."
  else
     set java_version (echo $current | sed -e 's|\(.*\) \?(.*|\1|g')
     set -xU JAVA_HOME (asdf where java $java_version)
  end
end
