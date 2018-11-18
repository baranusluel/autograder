%% setupRecs: Setup resources for solutions
function setupRecs(solutions, base)
    recs = Student.resources;
    recs.BasePath = base;
    recs.Problems = solutions;
end