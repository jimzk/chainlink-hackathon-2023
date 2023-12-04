按钮1
- 名字：Building circuits
- 打印内容
  1. Compiling Circuits...
  2. Done 66s.【sleep同等时间，下同】
  3. Generating zkey 0 ...
  4. Done 1244s
  5. Generating final key
  6. Done 349s

按钮2
- 名字：Pull prices and generate zk proof
- 打印内容
  1. Fetching price infos from chainlink datastream API... 【sleep 3秒】
    - 打印reports.json里的内容。（里面是一个list，有2个价格。做成折叠形式。）
  2. Generating circuit input...
    - 打印input.json里的内容（先折叠，不显示）
  3. Generating witness and zk proof【sleep 228s】
    - 打印proof.json里的内容（先折叠，不显示）
    - 打印public.json里的内容（先折叠，不显示）
  4. Done【228s】

按钮3
- 名字：Solidity Verifier
- 等待0.5秒，打印内容：
    - Price zk proof VERIFICATION SUCCESSFUL!
    - Gas Cost: 345719
