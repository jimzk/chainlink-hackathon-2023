import React from "react";
import "./App.css";
import { Container, Grid } from "@mui/material";
import BuildingOrSolidity from "./components/BuildingOrSolidity";
import Pull from "./components/Pull";
import reportsJson from "./components/Pull/reports.json";
import inputJson from "./components/Pull/input.json";
import proofJson from "./components/Pull/proof.json";
import publicJson from "./components/Pull/public.json";
const BuildingList = [
  {
    text: "Compiling Circuits...",
    time: 1,
  },
  {
    text: "Done 66s.",
    time: 66,
  },
  {
    text: "Generating zkey 0 ...",
    time: 1,
  },
  {
    text: "Done 1244s",
    time: 1244,
  },
  {
    text: "Generating final key",
    time: 1,
  },
  {
    text: "Done 349s",
    time: 349,
  },
];
const pullList = [
  {
    id: 1,
    name: "",
    text: "Fetching price infos from chainlink datastream API...",
    list: [],
    time: 3,
  },
  {
    id: 2,
    name: "reports.json",
    text: "",
    list: reportsJson,
    time: 1,
  },
  {
    id: 3,
    text: "Generating circuit input...",
    name: "",
    list: [],
    time: 1,
  },
  {
    id: 4,
    name: "input.json",
    text: "",
    list: inputJson,
    time: 1,
  },
  {
    id: 5,
    name: "",
    text: "Generating witness and zk proof",
    list: [],
    time: 228,
  },
  {
    id: 6,
    name: "proof.json",
    text: "",
    list: proofJson,
    time: 1,
  },
  {
    id: 7,
    name: "public.json",
    text: "",
    list: publicJson,
    time: 1,
  },
  {
    id: 8,
    name: "",
    text: "Done",
    list: [],
    time: 228,
  },
];
const SolidityList = [
  {
    text: "Price zk proof VERIFICATION SUCCESSFUL!",
    time: 0.5,
  },
  {
    text: "Gas Cost: 345719",
    time: 0.5,
  },
];
function App() {
  return (
    <div className="App">
      <Container sx={{ mt: 5 }}>
        <Grid sx={{ pt: 11 }} container spacing={11}>
          <Grid xs={3}>
            <BuildingOrSolidity
              list={BuildingList}
              buttonText="Building circuits"
            />
          </Grid>
          <Grid xs={4}>
            <Pull
              list={pullList}
              buttonText="Pull prices and generate zk proof"
            />
          </Grid>
          <Grid xs={4}>
            <BuildingOrSolidity
              list={SolidityList}
              buttonText="Solidity Verifier"
            />
          </Grid>
        </Grid>
      </Container>
    </div>
  );
}

export default App;
