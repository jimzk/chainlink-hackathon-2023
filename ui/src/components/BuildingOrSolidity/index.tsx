import { Stack, Button } from "@mui/material";
import React, { memo, useState } from "react";

const Index = memo<{
  buttonText: string;
  list: { text: string; time: number }[];
}>(({ buttonText, list }) => {
  const [displayText, setDisplayText] = useState<string[]>([]);

  const handleClick = (index: number) => {
    if (index < list.length) {
      setTimeout(() => {
        setDisplayText((prevList) => [...prevList, list[index].text]);
        handleClick(index + 1);
      }, list[index].time * 1000);
    }
  };

  return (
    <div>
      <Stack spacing={2}>
        <Button
          variant="contained"
          onClick={() => {
            handleClick(0);
          }}
        >
          {buttonText}
        </Button>
        {displayText.length > 0 &&
          displayText.map((item) => <p key={item}>{item}</p>)}
      </Stack>
    </div>
  );
});

export default Index;
