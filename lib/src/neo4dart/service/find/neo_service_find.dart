part of neo4dart;

class NeoServiceFind {

  final _logger = new Logger("NeoServiceFind");

  NeoClientGet neoClientGet = new NeoClientGet();

  BatchInsertExecutor tokenInsertExecutor = new BatchInsertExecutor();
  BatchFindExecutor tokenFindExecutor = new BatchFindExecutor();

  CypherFindInterpreter cypherFindInterpreter = new CypherFindInterpreter();
  CypherFindExecutor cypherFindExecutor = new CypherFindExecutor();

  Future findNodes(Type type, {Map properties}) {

    if(properties == null || properties.length == 0) {
      return neoClientGet.findNodesByType(type);
    }

    return neoClientGet.findNodesByTypeAndProperties(type, properties);
  }

  Future findNodeById(int id, Type type) {
    return tokenFindExecutor.findNodeById(id, type);
  }

  Future findNodesByIds(Iterable<int> ids, Type type) {
    return tokenFindExecutor.findNodesByIds(ids, type);
  }

  Future findNodeAndRelationsById(int id, Type type) {
    return tokenFindExecutor.findNodeAndRelationsById(id, type);
  }

  Future findAllNodeAndRelationsById(int id, Type type) {
    return cypherFindExecutor.findAllNodeAndRelationIds([id], type).then((response) {

      CypherResponse cypherResponse = cypherFindInterpreter.convertResponse(response);
      Set<int> nodeIds = cypherFindInterpreter.extractNodeIdsFromCypherResponse(cypherResponse);
      Set<int> relationshipIds = cypherFindInterpreter.extractRelationshipIdsFromCypherResponse(cypherResponse);

      return tokenFindExecutor.findAllNodesAndRelations(id, type, nodeIds, relationshipIds);
    });
  }
}
