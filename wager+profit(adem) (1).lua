modal    = balance
target   = 2000     -- target utama
target2  = modal * 0.1   -- target pertama
tpsesi   = modal * 0.01  -- target per sesi
startbet = modal * 1e-5  -- bet awal
stoploss = balance * 0.5 -- setting stoploss
pay1     = 900
pay2     = 1100
paysesi1 = 500
paysesi2 = 1500
payout   = math.random(pay1,pay2)/100 -- random payout
chance   = 99 / payout
nextbet  = startbet
bethigh  = true
cprofit  = 0
cprofit2 = 0
cls      = 0
won      = 0
ls       = 0
boomls   = 0
-----------------------------------------------------------

slowdown_ct = 0
slowdown_mx = 0
slowdown    = false
resetstats()
resetseed()
function dobet()
    if slowdown then
        slowdown_ct += 1
        nextbet = balance * 1e-3
        chance  = 93
        if slowdown_ct > slowdown_mx then
            slowdown_ct = 0 
            slowdown    = false
            cprofit     = 0
            cprofit2    = 0
            chance      = 99 / payout
            modal       = math.random(2000,2100)/100
            nextbet     = modal * 1e-5
        end
        print("\n░▒▓- Slow Down \t[ "..slowdown_ct.." / "..slowdown_mx.." ]\n")

    else

        cprofit2 += currentprofit
        cprofit += currentprofit
         
        if balance >= (modal*2) then -- jika profit 100%, stoploss ON
            if balance < stoploss then stop() end
        end
        if balance >= target then stop() end
        if cprofit2 > target2 then
            cprofit2 = 0
            resetseed()
            -- sleep(60000)
            if (bethigh == true) then -- switching bethigh
                bethigh = false
            else
                bethigh = true
            end
            payout  = math.random(pay1,pay2)/100
            chance  = 99 / payout
            modal   = balance
            nextbet = modal * 1e-5

            slowdown_mx = 600
            slowdown    = true
        end
           
        if cprofit > tpsesi then  -- TP per Sesi
            -- sleep(30000)
            cprofit = 0
            payout  = math.random(paysesi1,paysesi2)/100
            chance  = 99 / payout
            modal   = math.random(2000,2100)/100
            nextbet = modal * 1e-5
            resetseed()

            slowdown_mx = 300
            slowdown    = true
        end
        
        if win then
            ls     = 0
            boomls = 0
            won += 1
            if (won == 2) then
                if previousbet > 0.01 then 
                    nextbet = startbet
                else
                    nextbet = previousbet * 0.8
                end
                won     = 0
            else
                nextbet = startbet -- jika win 1 maka bet lanjut
            end
            
        else
            ls += 1
            boomls += 1
            cekls = ls / 50 -- varian multiple LS
            if cekls < 1 then
                multi = 1+((chance/100) * 1.5)
            elseif (cekls > 1 and cekls < 4) then
                multi = 1+((chance/100) *2)
            else
                multi = 1+((chance/100) * 3)
            end
            nextbet = previousbet * multi
        end
        
    end

end