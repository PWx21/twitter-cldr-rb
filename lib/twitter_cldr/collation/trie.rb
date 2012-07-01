# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

module TwitterCldr
  module Collation

    # This class represents a trie - a tree data structure, also known as a prefix tree.
    #
    # Every node corresponds to a single character of the key. To find the value by key one goes down the trie
    # starting from the root and descending one character at a time. If at some level current node doesn't have a
    # child corresponding to the next character of the key, then the trie doesn't contain a value with the given key.
    # Otherwise, the final node, corresponding to the last character of the key, should contain the value. If it's
    # nil, then the trie doesn't contain a value with the given key (or the value itself is nil).
    #
    class Trie

      # Initializes a new trie. If `trie_hash` value is passed it's used as the initial data for the trie. Usually,
      # `trie_hash` is extracted from other trie and represents its sub-trie.
      #
      def initialize(children = {})
        @root = Node.new(nil, children)
      end

      def starters
        @root.children.keys
      end

      def each_starting_with(starter, &block)
        starting_node = @root.child(starter)
        each_pair(starting_node, [starter], &block) if starting_node
      end

      def empty?
        @root.children.empty?
      end

      def add(key, value)
        store(key, value, false)
      end

      def set(key, value)
        store(key, value)
      end

      def get(key)
        final = key.inject(@root) do |node, key_element|
          return unless node
          node.child(key_element)
        end

        final && final.value
      end

      # Finds the longest substring of the `key` that matches, as a key, a node in the trie.
      #
      # Returns a three elements array:
      #
      #   1. value in the last node that was visited
      #   2. size of the `key` prefix that matches this node
      #   3. sub-trie for which that node is a root
      #
      def find_prefix(key)
        prefix_size = 0
        node = @root

        key.each do |key_element|
          child = node.child(key_element)

          if child
            prefix_size += 1
            node = child
          else
            break
          end
        end

        [node.value, prefix_size, self.class.new(node.children)]
      end

      def to_hash
        @root.children_hash
      end

      private

      def store(key, value, override = true)
        final = key.inject(@root) do |node, key_element|
          node.child(key_element) || node.set_child(key_element, Node.new)
        end

        final.value = value unless final.value && !override
      end

      def each_pair(node, key, &block)
        yield [key, node.value] if node.value

        node.children.each do |key_element, child|
          each_pair(child, key + [key_element], &block)
        end
      end

      class Node

        attr_accessor :value

        def initialize(value = nil, children = nil)
          @value    = value
          @children = children
        end

        def child(key)
          children[key]
        end

        def set_child(key, child)
          children[key] = child
        end

        def children
          @children ||= {}
        end

        def children_hash
          children.inject({}) { |memo, (key, child)| memo[key] = [child.value, child.children_hash]; memo }
        end

      end

    end

  end
end