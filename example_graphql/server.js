const { ApolloServer } = require("apollo-server");

const typeDefs = gql`
  type Customer {
    firstName: String
    id: Int
    lastName: String
    pizzas: [Pizza]
  }

  type Pizza {
    id: Int
    frozen: Boolean
    toppings: [String]
  }

  # Available queries
  type Query {
    allCustomers: [Customer]
    allPizzas: [Pizza]
  }
`;

const pizza = {
  "id": 1,
  "frozen": false,
  "toppings": [
    "pepperoni",
    "olive"
  ]
};
const people = [{
  "id": 1,
  "pizzas": [pizza],
  "firstName": "Wallace",
  "lastName": "Wallaceton"
}];

const resolvers = {
  Query: {
    allCustomers: () => people,
    allPizzas: () => [pizza],
  }
}

// The ApolloServer constructor requires two parameters: your schema
// definition and your set of resolvers.
const server = new ApolloServer({ typeDefs, resolvers });

// The `listen` method launches a web server.
server.listen().then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
