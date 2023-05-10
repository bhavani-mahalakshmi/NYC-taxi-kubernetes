from neo4j import GraphDatabase

class Interface:
    def __init__(self, uri, user, password):
        self._driver = GraphDatabase.driver(uri, auth=(user, password), encrypted=False)
        self._driver.verify_connectivity()

    def close(self):
        self._driver.close()

    def bfs(self, start_node, last_node):
        visited = []
        queue = [[start_node]]

        while queue:
            path = queue.pop(0)
            node = path[-1]

            if node == last_node:
                return [{"path": [{"name": n} for n in path]}]

            if node not in visited:
                visited.append(node)
                with self._driver.session() as session:
                    result = session.run("MATCH (a)-[r]->(b) WHERE a.name = $node RETURN b.name AS name", node=node)
                    for record in result:
                        neighbor = record["name"]
                        new_path = list(path)
                        new_path.append(neighbor)
                        queue.append(new_path)

        return []


    def pagerank(self, max_iterations, weight_property):
        with self._driver.session() as session:
            session.run("CALL gds.graph.project('tripsGraph','Location','TRIP', { relationshipProperties: [$weight_property] })", weight_property=weight_property)
            result = session.run("CALL gds.pageRank.stream('tripsGraph', {maxIterations: $max_iterations, relationshipWeightProperty: $weight_property}) YIELD nodeId, score RETURN gds.util.asNode(nodeId).name AS name, score", max_iterations=max_iterations, weight_property=weight_property)
            nodes = [(record["name"], record["score"]) for record in result]
            min_node = {"name": nodes[0][0], "score": nodes[0][1]}
            max_node = {"name": nodes[0][0], "score": nodes[0][1]}
            for node in nodes:
                if node[1] < min_node["score"]:
                    min_node["name"] = node[0]
                    min_node["score"] = node[1]
                if node[1] > max_node["score"]:
                    max_node["name"] = node[0]
                    max_node["score"] = node[1]
            return max_node, min_node
