import { Button } from "@mui/material";
import React, { memo, useEffect, useState } from "react";
import dayjs from "dayjs";

const Index = memo<{
  list: any[];
  id: number;
  name: string;
}>(({ list, name }) => {
  const [isShow, setIsShow] = useState(false);
  const [listInfo, setListInfo] = useState<any>(list);

  const renderInfo = () => {
    return (
      <pre style={{ textAlign: "left" }}>
        {JSON.stringify(listInfo, null, 2)}
      </pre>
    );
  };
  return (
    <div style={{ wordBreak: "break-all" }}>
      {(listInfo.length > 0 ||
        Object.prototype.toString.call(listInfo) === "[object Object]") && (
        <div>
          <span style={{ marginRight: 5 }}>{name}</span>
          <Button variant="contained" onClick={() => setIsShow(!isShow)}>
            {isShow ? "Hide" : "Show"}
          </Button>
        </div>
      )}
      <div
        style={{
          maxHeight: 500,
          overflow: "auto",
          height: isShow ? "100%" : 0,
        }}
      >
        {isShow ? renderInfo() : null}
      </div>
    </div>
  );
});

export default Index;
