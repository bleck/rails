module ActiveRelation
  class Predicate
    def ==(other)
      self.class == other.class
    end
  end

  class Binary < Predicate
    attr_reader :operand1, :operand2

    def initialize(operand1, operand2)
      @operand1, @operand2 = operand1, operand2
    end

    def ==(other)
      super and @operand1 == other.operand1 and @operand2 == other.operand2
    end
    
    def bind(relation)
      descend { |x| x.bind(relation) }
    end
    
    def qualify
      descend(&:qualify)
    end

    def to_sql(strategy = nil)
      "#{operand1.to_sql(operand2.strategy)} #{predicate_sql} #{operand2.to_sql(operand1.strategy)}"
    end
    
    def descend
      self.class.new(yield(operand1), yield(operand2))
    end
  end

  class Equality < Binary
    def ==(other)
      self.class == other.class and
        ((operand1 == other.operand1 and operand2 == other.operand2) or
         (operand1 == other.operand2 and operand2 == other.operand1))
    end

    protected
    def predicate_sql
      '='
    end
  end

  class GreaterThanOrEqualTo < Binary
    protected
    def predicate_sql
      '>='
    end
  end

  class GreaterThan < Binary
    protected
    def predicate_sql
      '>'
    end
  end

  class LessThanOrEqualTo < Binary
    protected
    def predicate_sql
      '<='
    end
  end

  class LessThan < Binary
    protected
    def predicate_sql
      '<'
    end
  end

  class Match < Binary
    alias_method :regexp, :operand2

    def initialize(operand1, regexp)
      @operand1, @regexp = operand1, regexp
    end
  end

  class RelationInclusion < Binary
    alias_method :relation, :operand2

    protected
    def predicate_sql
      'IN'
    end
  end
end