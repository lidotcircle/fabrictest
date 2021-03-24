import { Context, Contract, Transaction, JSONSerializer, Object, Property } from "fabric-contract-api";

@Object()
class CC1Data {
    @Property()
    no: number;
}

export class CC1 extends Contract {
    private async assertNotExist(ctx: Context, id: string) {
        const data = await ctx.stub.getState(id);
        if(data != null && data.length != 0) {
            throw new Error(`${id} has exist ${data.toString()}`);
        }
    }

    public async InitLedger(ctx: Context) {
        const dts: CC1Data[] = [
            {no: 1},
            {no: 2},
            {no: 3},
        ];

        for(let i=0;i<dts.length;i++) {
            const dt = dts[i];
            await ctx.stub.putState(`data-${i}`, Buffer.from(JSON.stringify(dt)));
        }
        console.log('init CC1 contract successful');
    }

    public async getContractData(ctx: Context) {
        const states = await ctx.stub.getStateByRange("", "");
        const ans: {[key: string]: CC1Data} = {};

        while(true) {
            const next = await states.next();
            if(next.done) break;
            const key = next.value.key;
            const val = JSON.parse(next.value.value.toString());
            ans[key] = val;
        }

        return ans;
    }

    public async setData(ctx: Context, id: string, data: CC1Data) {
        await this.assertNotExist(ctx, id);
        await ctx.stub.putState(id, Buffer.from(JSON.stringify(data)));
    }
}

