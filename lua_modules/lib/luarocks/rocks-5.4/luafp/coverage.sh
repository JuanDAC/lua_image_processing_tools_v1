rm luacov.report.out
rm luacov.report.out.index
rm luacov.stats.out
rm -rf ./coverage
rm -rf coverage
# busted test -c -p spec
busted --coverage spec
# luacov
luacov-console spec
luacov-console -s
# luacov-console -l predicates


# mkdir ./coverage
# cp luacov.stats.out ./coverage/lcov.info
# luacov-coveralls -i luafp -t 97tePdW8ffhc1OED7xCnW2EuDd2nyCVQ3
# istanbul report