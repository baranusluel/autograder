function json2unitTest(fname)
st = loadjson(fname);
ut = matlab.unittest.TestCase.forInteractiveUse();
for i = 1:length(st.tests)
    [~, ins, ~] = getFuncCallParts(st.tests{i});
    exp = feval(@cellCat_soln, ins{:});
    act = feval(@cellCat_stud, ins{:});
    ut.verifyEqual(exp, act); % can easily plug in tolerance here
end
