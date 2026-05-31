unit Query4D.Model.Types;

interface

type
  TQueryType = (qtSelect, qtInsert, qtUpdate, qtDelete);

  TJoinType = (jtInner, jtLeft, jtRight, jtFullOuter, jtCross);

  TWhereOperator = (
    woEqual,                  // =
    woNotEqual,               // <>
    woGreaterThan,            // >
    woGreaterThanOrEqualTo,   // >=
    woLessThan,               // <
    woLessThanOrEqualTo,      // <=
    woContains,               // LIKE '%val%'
    woNotContains,            // NOT LIKE '%val%'
    woStartsWith,             // LIKE 'val%'
    woEndsWith,               // LIKE '%val'
    woContainsCaseInsensitive,// LOWER(col) LIKE LOWER('%val%')
    woIsNull,                 // IS NULL
    woIsNotNull,              // IS NOT NULL
    woIsBetween,              // BETWEEN
    woIsNotBetween,           // NOT BETWEEN
    woIsIn,                   // IN (...)
    woIsNotIn,                // NOT IN (...)
    woIsInSubquery,           // IN (SELECT ...)  -- reservado
    woIsNotInSubquery,        // NOT IN (SELECT ...) -- reservado
    woIsTrue,                 // col = 1
    woIsFalse,                // col = 0
    woExists,                 // EXISTS
    woNotExists,              // NOT EXISTS
    woRaw                     // expressao crua
  );

  TLogicalOperator = (loAnd, loOr);

  TOrderDirection = (odAsc, odDesc);

  TNullsOrder = (noDefault, noFirst, noLast);

  TDialectFeature = (
    dfReturning,
    dfCTE,
    dfRecursiveCTE,
    dfNullsFirstLast,
    dfBulkInsert,
    dfILike,
    dfLimitOffset,
    dfFirstSkip,
    dfWindowFunctions
  );

  TSetValueKind = (svkLiteral, svkParam, svkRaw);

implementation

end.
