import { Stack, Button } from "@mui/material";
import React, { memo, useState } from "react";
import Fold from "../Fold";
const Index = memo<{
  buttonText: string;
  list: any[];
}>(({ buttonText, list }) => {
  const [info, setInfo] = useState<any[]>([]);

  const handleClick = (index: number) => {
    if (index < list.length) {
      setTimeout(() => {
        setInfo((prevList) => [...prevList, list[index]]);
        handleClick(index + 1);
      }, list[index].time * 1000);
    }
  };
  console.log(info, "info");

  return (
    <div>
      <Stack spacing={2}>
        <Button
          variant="contained"
          style={{ margin: "0 10px" }}
          onClick={() => {
            handleClick(0);
          }}
        >
          {buttonText}
        </Button>
        {info.length > 0 &&
          info.map((item, idx) => (
            <div key={idx}>
              {item.text ? <p style={{ margin: "15 0" }}>{item.text}</p> : ""}
              <Fold list={item.list} id={item.id} name={item.name} />
            </div>
          ))}
      </Stack>
    </div>
  );
});

export default Index;
