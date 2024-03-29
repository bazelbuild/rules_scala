// Copyright 2017 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package io.bazel.rulesscala.exe;

import io.bazel.rulesscala.preconditions.Preconditions;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Metadata that describes the payload of the native launcher binary.
 *
 * <p>This object constructs the binary metadata lazily, to save memory.
 */
public final class LaunchInfo {

  private final List<Entry> entries;

  private LaunchInfo(List<Entry> entries) {
    this.entries = entries;
  }

  /** Creates a new {@link Builder}. */
  public static Builder builder() {
    return new Builder();
  }

  /** Writes this object's entries to {@code out}, returns the total written amount in bytes. */
  long write(OutputStream out) throws IOException {
    long len = 0;
    for (Entry e : entries) {
      len += e.write(out);
      out.write('\0');
      ++len;
    }
    return len;
  }

  /** Writes {@code s} to {@code out} encoded as UTF-8, returns the written length in bytes. */
  private static long writeString(String s, OutputStream out) throws IOException {
    byte[] b = s.getBytes(StandardCharsets.UTF_8);
    out.write(b);
    return b.length;
  }

  /** Represents one entry in {@link LaunchInfo.entries}. */
  private interface Entry {
    /** Writes this entry to {@code out}, returns the written length in bytes. */
    long write(OutputStream out) throws IOException;
  }

  /** A key-value pair entry. */
  private static final class KeyValuePair implements Entry {
    private final String key;
    private final String value;

    public KeyValuePair(String key, String value) {
      this.key = Preconditions.requireNotNull(key);
      this.value = value;
    }

    @Override
    public long write(OutputStream out) throws IOException {
      long len = writeString(key, out);
      len += writeString("=", out);
      if (value != null && !value.isEmpty()) {
        len += writeString(value, out);
      }
      return len;
    }
  }

  /** A pair of a key and a delimiter-joined list of values. */
  private static final class JoinedValues implements Entry {
    private final String key;
    private final String delimiter;
    private final Iterable<String> values;

    public JoinedValues(String key, String delimiter, Iterable<String> values) {
      this.key = Preconditions.requireNotNull(key);
      this.delimiter = Preconditions.requireNotNull(delimiter);
      this.values = values;
    }

    @Override
    public long write(OutputStream out) throws IOException {
      long len = writeString(key, out);
      len += writeString("=", out);
      if (values != null) {
        boolean first = true;
        for (String v : values) {
          if (first) {
            first = false;
          } else {
            len += writeString(delimiter, out);
          }
          len += writeString(v, out);
        }
      }
      return len;
    }
  }

  /** Builder for {@link LaunchInfo} instances. */
  public static final class Builder {
    private List<Entry> entries = new ArrayList<>();

    /** Builds a {@link LaunchInfo} from this builder. This builder may be reused. */
    public LaunchInfo build() {
      return new LaunchInfo(Collections.unmodifiableList(entries));
    }

    /**
     * Adds a key-value pair entry.
     *
     * <p>Examples:
     *
     * <ul>
     *   <li>{@code key} is "foo" and {@code value} is "bar", the written value is "foo=bar\0"
     *   <li>{@code key} is "foo" and {@code value} is null or empty, the written value is "foo=\0"
     * </ul>
     */
    public Builder addKeyValuePair(String key, String value) {
      Preconditions.requireNotNull(key);
      if (!key.isEmpty()) {
        entries.add(new KeyValuePair(key, value));
      }
      return this;
    }

    /**
     * Adds a key and list of lazily-joined values.
     *
     * <p>Examples:
     *
     * <ul>
     *   <li>{@code key} is "foo", {@code delimiter} is ";", {@code values} is ["bar", "baz",
     *       "qux"], the written value is "foo=bar;baz;qux\0"
     *   <li>{@code key} is "foo", {@code delimiter} is irrelevant, {@code value} is null or empty,
     *       the written value is "foo=\0"
     * </ul>
     */
    public Builder addJoinedValues(String key, String delimiter, Iterable<String> values) {
      Preconditions.requireNotNull(key);
      Preconditions.requireNotNull(delimiter);
      if (!key.isEmpty()) {
        entries.add(new JoinedValues(key, delimiter, values));
      }
      return this;
    }
  }
}
