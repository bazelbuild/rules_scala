package io.bazel.rulesscala.worker;

import java.security.Permission;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class PermissionSecurityManager extends SecurityManager {
  @Override
  public void checkPermission(Permission permission) {
    Matcher matcher = exitPattern.matcher(permission.getName());
    if (matcher.find()) throw new ExitTrapped(Integer.parseInt(matcher.group(1)));
  }

  private static Pattern exitPattern = Pattern.compile("exitVM\\.(-?\\d+)");
}
